--Ｃｏｎｃｏｕｒｓ ｄｅ Ｃｕｉｓｉｎｅ～菓冷なる料理対決～
--Concours de Cuisine (Culinary Confrontation)
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Nouvelles" Pendulum Monster and 1 "Patissciel" Pendulum Monster from your hand, Deck, and/or Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Increase the ATK of a monster by 200 x the number of "Recipe" cards in the GYs
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NOUVELLES,SET_PATISSCIEL,SET_RECIPE}
local locs=LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA
function s.cfilter(c,archetyp)
	return c:IsSetCard(archetyp) and c:IsType(TYPE_PENDULUM)
end
function s.firstsummon(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
		and sg:IsExists(s.secondsummon,1,c,e,tp) --exclude 'c'
end
function s.secondsummon(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		and ((not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0)
		or Duel.GetLocationCountFromEx(1-tp,tp,nil,c)>0)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSetCard,nil,SET_PATISSCIEL)==1
		and sg:FilterCount(Card.IsSetCard,nil,SET_NOUVELLES)==1
		and sg:IsExists(s.firstsummon,1,nil,e,tp,sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.cfilter,tp,locs,0,nil,SET_NOUVELLES)
	local g2=Duel.GetMatchingGroup(s.cfilter,tp,locs,0,nil,SET_PATISSCIEL)
	local g=g1+g2
	if chk==0 then return #g1>0 and #g2>0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,locs)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Cannot use monsters as material for a Fusion/Synchro/Xyz/Link Summon, except "Nouvelles" and "Patissciel" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e1:SetTarget(function(e,c) return not c:IsSetCard({SET_NOUVELLES,SET_PATISSCIEL}) end)
	e1:SetValue(s.sumlimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	Duel.RegisterEffect(e4,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	--Special Summon 1 "Nouvelles" monster and 1 "Patissciel" monster
	local g1=Duel.GetMatchingGroup(s.cfilter,tp,locs,0,nil,SET_NOUVELLES)
	local g2=Duel.GetMatchingGroup(s.cfilter,tp,locs,0,nil,SET_PATISSCIEL)
	if #g1==0 or #g2==0 then return end
	local g=g1+g2
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #sg~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sc1=sg:FilterSelect(tp,s.firstsummon,1,1,nil,e,tp,sg):GetFirst()
	local sc2=sg:RemoveCard(sc1):GetFirst()
	Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep(sc2,0,tp,1-tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
end
function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,SET_RECIPE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,SET_RECIPE)
	if ct==0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:UpdateAttack(ct*200,RESET_EVENT|RESETS_STANDARD,e:GetHandler())
	end
end