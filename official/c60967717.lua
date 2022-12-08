--ミュートリア超個体系
--Myutant Expansion
--Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Activate and, optionally, either add to hand or Special Summon 1 "Myutant" monster from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Destruction replacement for Level 8 or higher "Myutant" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
	--Lists "Myutant" archetype
s.listed_series={SET_MYUTANT}
	--Check for level 4 or lower "Myutant" monster
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_MYUTANT) and c:IsLevelBelow(4)
		and (c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.rescon(fg)
	return function(sg,e,tp)
		return sg:IsExists(Card.IsAbleToHand,1,nil)
			or (ft>0 and sg:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false))
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if aux.SelectUnselectGroup(g,e,tp,1,1,s.rescon(ft),0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local tc=aux.SelectUnselectGroup(g,e,tp,1,1,s.rescon(ft),1,tp,HINTMSG_SELECT):GetFirst()
		if tc then
		aux.ToHandOrElse(tc,tp,
			function() return ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
			function() Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,2))
		end
	end
end
	--Check for a level 8+ "Myutant" monster
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MYUTANT) and c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(8)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
	--Activtion legality
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
	--Banish itself as substitute for a level 8+ "Myutant" monster's destruction
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end