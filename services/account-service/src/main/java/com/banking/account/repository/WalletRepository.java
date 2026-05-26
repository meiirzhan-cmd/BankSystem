package com.banking.account.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.banking.account.entity.Wallet;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, UUID> {
    List<Wallet> findByUserId(String userId);

    List<Wallet> findByUserIdAndStatus(String userId, Wallet.WalletStatus status);

    @Query("""
        SELECT w FROM Wallet w
        LEFT JOIN FETCH w.cards
        WHERE w.userId = :userId AND w.status = 'ACTIVE'
        """)
    List<Wallet> findActiveWalletsWithCards(String userId);

    boolean existsByUserIdAndWalletType(String userId, Wallet.WalletType walletType);
}
