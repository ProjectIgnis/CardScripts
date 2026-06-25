--JP name
--Checkker
--Scripted by The Razgriz
local s,id=GetID()
local TOKEN_IRON_RUBBLE=id+100
function s.initial_effect(c)
	--Cannot be Normal Summoned if you control a monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0 end)
	c:RegisterEffect(e0)
	--You can Tribute this card; Special Summon 1 Machine monster from your Deck whose ATK equals its own DEF, but return it to the hand during the End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.spfromdecktg)
	e1:SetOperation(s.spfromdeckop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY and discard 1 card; Special Summon 1 "Iron Rubble Token" (Machine/EARTH/Level 1/ATK 0/DEF 0), but it cannot be used as material for a Fusion, Synchro, or Link Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.AND(Cost.SelfBanish,Cost.Discard()))
	e2:SetTarget(s.tokensptg)
	e2:SetOperation(s.tokenspop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_IRON_RUBBLE}
function s.spfromdeckfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsDefense(c:GetAttack()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfromdecktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfromdeckfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfromdeckop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfromdeckfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Return it to the hand during the End Phase
		aux.DelayedOperation(g,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,nil,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,2))
	end
end
function s.tokensptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_IRON_RUBBLE,0,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tokenspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_IRON_RUBBLE,0,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(tp,TOKEN_IRON_RUBBLE)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			--It cannot be used as material for a Fusion, Synchro, or Link Summon
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end