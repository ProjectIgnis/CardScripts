--ＲＵＭ－光波衝撃
--Rank-Up-Magic Cipher Shock
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0xe5}
function s.filter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return #pg<=1 and c:IsSetCard(SET_CIPHER) and c:IsCanBeEffectTarget(e) and (c:GetRank()>0 or c:IsStatus(STATUS_NO_LEVEL))
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1,pg)
end
function s.spfilter(c,e,tp,mc,rk,pg)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsType(TYPE_XYZ) and mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsSetCard(SET_CIPHER) and c:IsRank(rk) and mc:IsCanBeXyzMaterial(c,tp)
		and (#pg<=0 or pg:IsContains(mc)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.CreateGroup()
	if a and a:IsControler(tp) then g:AddCard(a) end
	if d and d:IsControler(tp) then g:AddCard(d) end
	if chkc then return g:IsContains(chkc) and s.filter(chkc,e,tp) end
	if chk==0 then return g:IsExists(s.filter,1,nil,e,tp) end
	local fid=e:GetFieldID()
	local sg=g:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	Duel.SetTargetCard(sg)
	local fg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=fg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(51104421,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,fid)
		tc=fg:GetNext()
	end
	Duel.SetTargetParam(fid)
end
function s.disfilter(c,fid)
	return c:GetFlagEffect(51104421)>0 and c:GetFlagEffectLabel(51104421)==fid
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local fid=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,fid)
	for dc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dc:RegisterEffect(e2)
	end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(s.sumcon)
	e3:SetOperation(s.sumop)
	e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e3:SetLabelObject(tc)
	Duel.RegisterEffect(e3,tp)
end
function s.sumcon(e,tp,eg,ev,ep,re,r,rp)
	return e:GetLabelObject():GetBattledGroupCount()~=0
end
function s.sumop(e,tp,eg,ev,ep,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	Duel.BreakEffect()
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,pg):GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end