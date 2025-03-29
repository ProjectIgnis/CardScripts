--セラの蟲惑魔
--Traptrix Sera
--scripted by Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Link summon method
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Unaffected by trap effects, continuous effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Special summon a "Traptrix" monster from deck, optional trigger effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Set 1 "Trap Hole" normal trap card from deck, optional trigger effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_TRAPTRIX,SET_TRAP_HOLE,SET_HOLE}
	--Link material of a non-link "Traptrix" monster
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_TRAPTRIX,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
	--If this card was link summoned
function s.immcon(e)
	return e:GetHandler():IsLinkSummoned()
end
	--Unaffected by trap effects
function s.efilter(e,te)
	return te:IsTrapEffect()
end
	--If a normal trap card is activated
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetActiveType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
	--Check names of monsters
function s.namefilter(c,cd)
	return c:IsCode(cd) and c:IsFaceup()
end
	--Check for "Traptrix" monster
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(s.namefilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
	--Performing the effect of special summoning a "Traptrix" monster with different name from controlled monsters
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
	--If your "Traptrix" monster effect activates, except this card
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsMonsterEffect()
		and re:GetHandler():IsSetCard(SET_TRAPTRIX) and re:GetHandler()~=e:GetHandler()
end
	--Check for "Trap Hole" normal trap
function s.setfilter(c)
	return (c:IsSetCard(SET_TRAP_HOLE) or c:IsSetCard(SET_HOLE)) and c:IsNormalTrap() and c:IsSSetable()
end
	--Activation legality
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
	--Performing the effect of setting 1 "Trap Hole" normal trap from deck to S/T zones
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end