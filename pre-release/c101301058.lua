--アルトメギア・バーニッシュ－改変－
--Artmegia Banish - Change
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Artmegia the Academy City of Divine Arts" from your Deck or GY face-up in your Field Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Negate an attack targeting your "Artmegia" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_MEDIUS_THE_INNOCENT,101301054,id} --"Artmegia the Academy City of Divine Arts"
s.listed_series={SET_ARTMEGIA}
function s.plthfilter(c,tohand_chk)
	return (c:IsCode(101301054) and not c:IsForbidden()) or (tohand_chk and c:IsSetCard(SET_ARTMEGIA) and c:IsAbleToHand() and c:IsLocation(LOCATION_DECK) and not c:IsCode(id))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tohand_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,101301054),tp,LOCATION_ONFIELD,0,1,nil)
		return Duel.IsExistingMatchingCard(s.plthfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tohand_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tohand_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,101301054),tp,LOCATION_ONFIELD,0,1,nil)
	local hint_desc=tohand_chk and aux.Stringid(id,2) or HINTMSG_TOFIELD
	Duel.Hint(HINT_SELECTMSG,tp,hint_desc)
	local sc=Duel.SelectMatchingCard(tp,s.plthfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tohand_chk):GetFirst()
	if not sc then return end
	if sc:IsCode(101301054) then
		if not tohand_chk then
			Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		else
			aux.ToHandOrElse(sc,tp,
				function() return tohand_chk and not sc:IsForbidden() end,
				function() Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) end,
				aux.Stringid(id,3)
			)
		end
	else
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	return bc and bc:IsSetCard(SET_ARTMEGIA) and bc:IsControler(tp) and bc:IsFaceup()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end 
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_MEDIUS_THE_INNOCENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end