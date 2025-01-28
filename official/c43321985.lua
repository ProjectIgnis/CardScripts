--エンシェント・フェアリー・ライフ・ドラゴン
--Ancient Fairy Life Dragon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Draw 1 card, or add 1 LIGHT Beast, Plant, or Fairy monster, or 1 "Eternal Sunshine" from your Deck to your hand instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.drthtg)
	e1:SetOperation(s.drthop)
	c:RegisterEffect(e1)
	--Your "Ancient Fairy Dragon" and monsters that mention it can attack while in face-up Defense Position. If they do, apply their DEF for damage calculation
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsCode(CARD_ANCIENT_FAIRY_DRAGON) or c:ListsCode(CARD_ANCIENT_FAIRY_DRAGON) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={5414777,28903523,CARD_ANCIENT_FAIRY_DRAGON} --"The World of Spirits", "Eternal Sunshine"
function s.thfilter(c)
	return ((c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST|RACE_PLANT|RACE_FAIRY)) or c:IsCode(28903523)) and c:IsAbleToHand()
end
function s.drthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local world_of_spirits_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,5414777),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b1=not world_of_spirits_chk and Duel.IsPlayerCanDraw(tp,1)
	local b2=world_of_spirits_chk and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	if b1 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.drthop(e,tp,eg,ep,ev,re,r,rp)
	local world_of_spirits_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,5414777),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if not world_of_spirits_chk then
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end