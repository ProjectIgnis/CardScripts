--Cards from the Blessed Grass
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ct1=eg:FilterCount(s.cfilter,nil,tp)
	local ct2=eg:FilterCount(s.cfilter,nil,1-tp)
	s[tp]=s[tp]+ct1
	s[1-tp]=s[1-tp]+ct2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s[tp]>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=s[tp] 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28062326,0,TYPES_TOKEN,800,500,1,RACE_PLANT,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,s[tp],0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,s[tp],tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<s[tp] then return end
	if ft>s[tp] then ft=s[tp] end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ft
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28062326,0,TYPES_TOKEN,800,500,1,RACE_PLANT,ATTRIBUTE_EARTH) then
		for i=1,ft do
			local token=Duel.CreateToken(tp,28062326)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
