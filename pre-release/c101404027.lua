--ブルーアイズ・カオス・ＭＡＸＩＭＵＭ・ドラゴン
--Blue-Eyes Chaos MAXIMUM Dragon
--scripted by pyrQ
local s,id=GetID()
local CARD_NEO_CHAOS_FORM=101404050
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeRitualSummoned()
	--You can banish this card from your hand; add 1 "Neo Chaos Form" from your Deck, GY, or banishment to your hand. You can only use this effect of "Blue-Eyes Chaos MAXIMUM Dragon" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If your monster that mentions "Endless Darkness" attacks a Defense Position monster, inflict piercing battle damage to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c)
		return c:ListsCode(CARD_ENDLESS_DARKNESS)
	end)
	c:RegisterEffect(e2)
	--Any battle damage your opponent takes from battles involving this card is doubled
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
s.listed_names={21082832,CARD_NEO_CHAOS_FORM,CARD_ENDLESS_DARKNESS} --"Chaos Form"
function s.thfilter(c)
	return c:IsCode(CARD_NEO_CHAOS_FORM) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end