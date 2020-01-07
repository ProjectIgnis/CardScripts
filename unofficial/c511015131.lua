--Doll House
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.gchk)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.gclear)
		Duel.RegisterEffect(ge2,0)
	end)
end
s_g=Group.CreateGroup()
function s.gchk(e,tp,eg,ev,ep,re,r,rp)
	local c=eg:GetFirst()
	while c do
		if c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1517) then
			s_g:AddCard(c) 
		end
		c=eg:GetNext()
	end
end
function s.gclear(e,tp,eg,ev,ep,re,r,rp)
	if s_g then
		s_g:Clear()
	end
end
function s.sfilter(c,e,tp,g)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1517) and 
		g:IsExists(function (c,lv) return c:GetLevel()==lv end,1,nil,c:GetLevel()-2) and
		c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local n=#s_g
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ft>0 then ft=2 end
	return n>1 and n<=ft and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,n-1,nil,e,tp,s.g)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local n=#s_g
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ft>0 then ft=2 end
	if n>ft then n=ft end
	local tg=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,n-1,n-1,nil,e,tp,s.g)
	Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
end
