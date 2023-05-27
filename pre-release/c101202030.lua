--覇王天龍オッドアイズ・アークレイ・ドラゴン
--Supreme Celestial King Odd-Eyes Arc-Ray Dragon
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c,false)
	c:EnableReviveLimit()
	--4 Dragon monsters (1 Fusion, 1 Synchro, 1 Xyz, and 1 Pendulum)
	Fusion.AddProcMix(c,true,true,s.matfilter(TYPE_FUSION),s.matfilter(TYPE_SYNCHRO),s.matfilter(TYPE_XYZ),s.matfilter(TYPE_PENDULUM))
	--Must be either Fusion Summoned or Special Summoned by alternate procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--Alternate Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Place 1 Pendulum Monster in the Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
	--Place itself into pendulum zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_ZARC}
function s.matfilter(typ)
	return function(c,fc,sumtype,tp)
		return c:IsRace(RACE_DRAGON,fc,sumtype,tp) and c:IsType(typ,fc,sumtype,tp)
	end
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st) or aux.penlimit(e,se,sp,st)
end
function s.hspfilter(c,tp,sc)
	return c:IsCode(CARD_ZARC) and c:IsLevel(12) and c:IsAttribute(ATTRIBUTE_DARK) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if not c then return true end
	if c:IsFaceup() then return false end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if not g then return false end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_PZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_PZONE,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
	Duel.BreakEffect()
	if Duel.SendtoDeck(sc,nil,1,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA)
		and sc:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.plfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end