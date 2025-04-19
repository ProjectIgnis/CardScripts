--RUM－バリアンズ・フォース (Anime)
--Rank-Up-Magic Barian's Force (Anime)
Duel.LoadScript("c420.lua")
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		local c=e:GetHandler()
		--Negate battle indestruction
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BATTLE_INDES)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetValue(s.batval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
		--Detach
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_ATKCHANGE)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_LEAVE_FIELD)
		e2:SetTarget(s.dettg)
		e2:SetOperation(s.detop)
		e2:SetLabelObject(sc)
		e2:SetReset(RESET_CHAIN)
		c:RegisterEffect(e2)
	end
end
function s.batval(e,re,c)
	return (re:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE or re:GetCode()==EFFECT_INDESTRUCTABLE_COUNT)
		and (not re:IsHasType(EFFECT_TYPE_SINGLE) or re:GetOwner()==c)
		and (not re:IsHasType(EFFECT_TYPE_FIELD) or re:GetActivateLocation()>0)
		and not re:GetHandler():IsHasEffect(EFFECT_CANNOT_DISABLE)
		and not re:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
end
function s.detfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.dettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.detfilter(chkc) end
	if chk==0 then return sc and Duel.IsExistingTarget(s.detfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.detfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.detop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and sc then
		local og=tc:GetOverlayGroup()
		if #og==0 then return end
		if Duel.SendtoGrave(og,REASON_EFFECT)>0 then
			Duel.Overlay(sc,og)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(#og*-300)
			tc:RegisterEffect(e1)
		end
	end
end