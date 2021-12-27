--超越融合
--Ultra Polymerization (Anime)
--Fixed and cleaned up by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76647978,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.mfilter(c)
	return not c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON) and (c:IsStatus(STATUS_PROC_COMPLETE) or not c:IsType(TYPE_EXTRA+TYPE_RITUAL))
end
function s.spfilter(c,e,tp,mg)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,tp)
end
function s.rescon(sg,e,tp,mg)
	if sg:IsExists(Card.IsInExtraMZone,1,nil) or (not Duel.GetFieldCard(tp,LOCATION_MZONE,5) and not Duel.GetFieldCard(tp,LOCATION_MZONE,6)) then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg) and Duel.GetMZoneCount(tp,sg)>1 end
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg) and Duel.GetMZoneCount(tp,sg)>2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsCanBeEffectTarget,nil):Filter(Card.IsLocation,nil,LOCATION_MZONE):Filter(s.mfilter,nil)
	if chk==0 then return aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,0) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.IsPlayerCanSpecialSummonCount(tp,2) end
	local g=aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,1,tp,HINTMSG_FMATERIAL,nil,nil,false)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.mspfilter(c,e,tp)
	return c:IsRelateToEffect(e) and not c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON) and (c:IsStatus(STATUS_PROC_COMPLETE) or not c:IsType(TYPE_EXTRA+TYPE_RITUAL))
end
function s.lvfilter(c)
	return not (c:IsLevel(4))
end
function s.tunerfilter(c)
	return not c:IsType(TYPE_TUNER)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not aux.SelectUnselectGroup(tg,e,tp,2,2,s.rescon,0) or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	local g=tg:Filter(aux.NecroValleyFilter(s.mspfilter),nil,e,tp)
	if #g<2 or g:IsExists(Card.IsControler,1,nil,1-tp) or g:IsExists(Card.IsImmuneToEffect,1,nil,e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
	tc:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_FUSION+REASON_EFFECT)
	local zone=0xff
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then
		zone=zone&~0x1f
	end
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP,zone) then
		tc:CompleteProcedure()
		Duel.BreakEffect()
		local fid=e:GetHandler():GetFieldID()
		for tc in g:Iter() do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			tc:RegisterFlagEffect(51116005,RESET_PHASE+PHASE_END,0,1,fid)
		end
		Duel.SpecialSummonComplete()
		local con1=g:IsExists(s.lvfilter,1,nil)
		local con2=g:IsExists(s.tunerfilter,1,nil)
		local op
		if (con1 or con2) and Duel.SelectYesNo(tp,65) then
			op=aux.SelectEffect(tp,{con1,aux.Stringid(id,0)},{con2,aux.Stringid(id,1)})
		end
		if op==1 then
			for gc in g:Iter() do
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CHANGE_LEVEL)
				e2:SetValue(4)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				gc:RegisterEffect(e2)
			end
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			local tug=g:FilterSelect(tp,s.tunerfilter,1,1,nil)
			Duel.HintSelection(tug)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_TUNER)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tug:GetFirst():RegisterEffect(e2)
		end
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		g:KeepAlive()
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetLabel(fid)
		e3:SetLabelObject(g)
		e3:SetCountLimit(1)
		e3:SetCondition(s.descon)
		e3:SetTarget(s.destg)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_BE_MATERIAL)
		e4:SetLabelObject(g)
		e4:SetOperation(s.checkop)
		e4:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e4,tp)
	end
end
function s.chkfilter(c,fid)
	return c:GetFlagEffectLabel(51116005)==fid and c:GetFlagEffect(id)>0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	return not g:IsExists(s.chkfilter,2,nil,e:GetLabel())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local dg=Duel.GetOperatedGroup()
		Duel.BreakEffect()
		local dam=dg:GetSum(Card.GetPreviousAttackOnField)
		Duel.Damage(tp,dam,REASON_EFFECT)
	end
end
function s.filter(c,g)
	return g:IsContains(c)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g then return end
	local sg=eg:Filter(s.filter,nil,g)
	if #sg>0 and (r==REASON_SYNCHRO or r==REASON_XYZ) then
		local tc=sg:GetFirst()
		while tc do
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,0)
			tc=sg:GetNext()
		end
	end
end
