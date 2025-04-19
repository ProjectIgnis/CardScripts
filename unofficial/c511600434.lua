--ＲＵＭ－ヌメロン・フォース (Anime)
--Rank-Up-Magic Numeron Force (Anime)
--Scripted by Larry126
Duel.LoadScript("c420.lua")
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon 1 "C" Xyz Monster, that is 1 rank higher than targeted Xyz
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,e,tp)
	local rk=c:GetRank()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and c:IsFaceup() and (rk>0 or c:IsStatus(STATUS_NO_LEVEL))
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
end
function s.spfilter(c,e,tp,mc,rk)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsType(TYPE_XYZ) and c:IsC()
		and c:IsRank(rk) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c):ForEach(function(gc) gc:NegateEffects(c,RESET_PHASE|PHASE_END,true) end)
	end
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1):GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		--Negate battle indestruction
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BATTLE_INDES)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetValue(s.batval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
end
function s.batval(e,re,c)
	return (re:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE or re:GetCode()==EFFECT_INDESTRUCTABLE_COUNT)
		and (not re:IsHasType(EFFECT_TYPE_SINGLE) or re:GetOwner()==c)
		and (not re:IsHasType(EFFECT_TYPE_FIELD) or re:GetActivateLocation()>0)
		and not re:GetHandler():IsHasEffect(EFFECT_CANNOT_DISABLE)
		and not re:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
end