--月朧龍ヴァグナワ
--Vagnawa the Moon-Eating Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Check the Tuner material's Level
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetLabel(0)
	e0:SetValue(s.valcheck)
	e0:SetOperation(s.matop)
	c:RegisterEffect(e0)
	--Make this card gain ATK and inflict damage to your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
end
function s.puretuner(c,sc,tp)
	return not c:IsHasEffect(EFFECT_NONTUNER) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)
end
function s.othertuner(c,sc,tp)
	return (c:IsHasEffect(EFFECT_NONTUNER) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp))
		or c:IsHasEffect(EFFECT_CAN_BE_TUNER)
end
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if #mg==0 then return e:SetLabel(0) end
	local tp=e:GetHandlerPlayer()
	local pure_tuner_g=mg:Filter(s.puretuner,nil,c,tp)
	if #pure_tuner_g>0 then
		local tunerlv=pure_tuner_g:GetFirst():GetSynchroLevel(c)
		e:SetLabelObject(nil)
		e:SetLabel(tunerlv,c:GetLevel()-tunerlv)
		return
	end
	local other_tuner_g=mg:Filter(s.othertuner,nil,c,tp)
	if #other_tuner_g>1 then
		e:SetLabelObject(other_tuner_g)
	else
		local tunerlv=other_tuner_g:GetFirst():GetSynchroLevel(c)
		e:SetLabelObject(nil)
		e:SetLabel(tunerlv,c:GetLevel()-tunerlv)
	end
end
function s.matop(e,c)
	local g=e:GetLabelObject()
	if not g then return end
	local tp=e:GetHandlerPlayer()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tuner=g:Select(tp,1,1,nil):GetFirst()
	Duel.HintSelection(tuner,true)
	local tunerlv=tuner:GetSynchroLevel(c)
	e:SetLabel(tunerlv,e:GetHandler():GetLevel()-tunerlv)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():GetLabel()>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,300)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tuner_lv,nontuner_lv=e:GetLabelObject():GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Gains ATK equal to the total Levels of the non-Tuners used x 300
		e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(nontuner_lv*300)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END,2)
		c:RegisterEffect(e1)
		Duel.BreakEffect()
		Duel.Damage(1-tp,tuner_lv*300,REASON_EFFECT)
	end
end