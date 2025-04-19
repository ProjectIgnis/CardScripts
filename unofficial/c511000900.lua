--レイジ・リシンクロ
--Rage Resynchro
--Updated by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp,mg)
	if not c.synchro_type or not c:IsType(TYPE_SYNCHRO) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local proceff={c:GetCardEffect(EFFECT_SPSUMMON_PROC)}
	for _,eff in ipairs(proceff) do
		if (eff:GetValue()&SUMMON_TYPE_SYNCHRO)~=0 then
			if eff:GetCondition()(eff,c,nil,mg) then return true end
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	if chkc then return #mg>0 and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,mg) end
	if chk==0 then return #mg>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	if tc and tc:IsRelateToEffect(e) and #mg>0 and s.filter(tc,e,tp,mg) then
		local proceff={tc:GetCardEffect(EFFECT_SPSUMMON_PROC)}
		local effs={}
		for _,eff in ipairs(proceff) do
			if (eff:GetValue()&SUMMON_TYPE_SYNCHRO)~=0 then
				if eff:GetCondition()(eff,tc,nil,mg) then table.insert(effs,eff) end
			end
		end
		local eff=effs[1]
		if #effs>1 then
			local desctable = {}
			for _,index in ipairs(effs) do
				table.insert(desctable,index:GetDescription())
			end
			eff=effs[Duel.SelectOption(tp,false,table.unpack(desctable)) + 1]
		end
		if eff:GetTarget()(eff,tp,nil,nil,nil,e,nil,nil,nil,tc,nil,mg) and Duel.SendtoGrave(eff:GetLabelObject(),REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)>0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetOperation(s.desop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			e2:SetLabel(0)
			e2:SetCountLimit(1)
			tc:RegisterEffect(e2,true)
		end
		eff:SetLabelObject(nil)
		Duel.SpecialSummonComplete()
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()>0 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	else
		e:SetLabel(1)
	end
end