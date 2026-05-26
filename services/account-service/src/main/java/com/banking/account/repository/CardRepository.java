package com.banking.account.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.banking.account.entity.Card;

@Repository
public interface CardRepository extends JpaRepository<Card, UUID> {

    List<Card> findByWalletId(UUID walletId);

    List<Card> findByWalletUserIdAndStatus(String userId, Card.CardStatus status);
}