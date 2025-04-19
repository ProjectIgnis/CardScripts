--無限光アイン・ソフ・オウル (Anime)
--Infinite Light (Anime)
local s,id=GetID()
local LOCATION_HDG=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE
function s.initial_effect(c)
	--Activate by sending 1 "Endless Emptiness" from your field to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--You can Special Summon Level 10 or higher monsters from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(102380,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--"Timelord" monsters you control cannot activate their effects in the Standby Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.accon)
	e3:SetValue(s.aclimit)
	c:RegisterEffect(e3)
	--Allows you to control more than 1 "Timelord" monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(513000047)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_TIMELORD))
	c:RegisterEffect(e4)
	--Special Summon "Sephylon, the Ultimate Timelord" from your hand, Deck or GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(2407147,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.sephcon)
	e5:SetCost(s.sephcost)
	e5:SetTarget(s.sephtg)
	e5:SetOperation(s.sephop)
	c:RegisterEffect(e5)
	--"Timelord" monster Summon register
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		s[2]={}
		s[3]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge3,0)
	end)
end
s.listed_series={SET_TIMELORD}
s.listed_names={36894320,8967776}
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(36894320) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) or 
		(c:IsOriginalCode(513000052) and c:IsLevelAbove(10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if #g>0 then
		if g:IsExists(Card.IsOriginalCode,1,nil,513000052) then
			local g1,g2=g:Split(Card.IsOriginalCode,nil,513000052)
			for tc in g1:Iter() do
				Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
			end
			for sc in g2:Iter() do
				Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
			end
			Duel.SpecialSummonComplete()
		else
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.accon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:GetActivateLocation()==LOCATION_MZONE and rc:IsSetCard(SET_TIMELORD) and not rc:IsImmuneToEffect(e)
end
function s.cfilter(c,tp)
	return c:IsSetCard(SET_TIMELORD) and c:IsFaceup() and c:IsSummonPlayer(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g1=eg:Filter(s.cfilter,nil,tp)
	local g2=eg:Filter(s.cfilter,nil,1-tp)
	local tc1=g1:GetFirst()
	while tc1 do
		if s[tp]==0 then
			s[2+tp][1]=tc1:GetCode()
			s[tp]=s[tp]+1
		else
			local chk=true
			for i=1,s[tp]+1 do
				if s[2+tp][i]==tc1:GetCode() then
					chk=false
				end
			end
			if chk then
				s[2+tp][s[tp]+1]=tc1:GetCode()
				s[tp]=s[tp]+1
			end
		end
		tc1=g1:GetNext()
	end
	while tc2 do
		if s[1-tp]==0 then
			s[2+1-tp][1]=tc2:GetCode()
			s[1-tp]=s[1-tp]+1
		else
			local chk=true
			for i=1,s[1-tp]+1 do
				if s[2+1-tp][i]==tc2:GetCode() then
					chk=false
				end
			end
			if chk then
				s[2+1-tp][s[1-tp]+1]=tc2:GetCode()
				s[1-tp]=s[1-tp]+1
			end
		end
		tc2=g2:GetNext()
	end
end
function s.sephcon(e,tp,eg,ep,ev,re,r,rp)
	return s[tp]>=10
end
function s.sephcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.sephspfilter(c,e,tp)
	return c:IsCode(8967776) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) 
end
function s.sephtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.sephspfilter,tp,LOCATION_HDG,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HDG)
end
function s.sephop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sephspfilter),tp,LOCATION_HDG,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end