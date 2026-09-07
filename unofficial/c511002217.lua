--恩恵の札草
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
	--Check for cards added from the Deck to the hand
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
end
s.listed_names={511001375} --"Plant Token (Manga)"
function s.cfilter(c,p)
	return c:IsControler(p) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ct1=eg:FilterCount(s.cfilter,nil,tp)
	local ct2=eg:FilterCount(s.cfilter,nil,1-tp)
	s[tp]=s[tp]+ct1
	s[1-tp]=s[1-tp]+ct2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=s[tp]
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ct>0 and ft>=ct and not (ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511001375,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=s[tp]
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<ct or (ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	if ft>ct then ft=ct end
	if ft>=ct and Duel.IsPlayerCanSpecialSummonMonster(tp,511001375,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) then
		for i=1,ct do
			local token=Duel.CreateToken(tp,511001375)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end
