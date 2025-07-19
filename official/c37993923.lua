--ジャンク・ガードナー
--Junk Gardna
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: "Junk Synchron" + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	--Change the battle position of 1 monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.postg(true))
	e1:SetOperation(s.posop(true))
	c:RegisterEffect(e1)
	--Change the battle position of 1 monster on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.postg(false))
	e2:SetOperation(s.posop(false))
	c:RegisterEffect(e2)
end
s.material={CARD_JUNK_SYNCHRON}
s.listed_names={CARD_JUNK_SYNCHRON}
s.material_setcode=SET_SYNCHRON
function s.tunerfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,CARD_JUNK_SYNCHRON) or c:IsHasEffect(20932152)
end
function s.postg(oppo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			if chkc then return (chkc:IsControler(1-tp) or not oppo) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
			local location=oppo and 0 or LOCATION_MZONE
			if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,location,LOCATION_MZONE,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,location,LOCATION_MZONE,1,1,nil)
			Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
		end
end
function s.posop(oppo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) and (tc:IsControler(1-tp) or not oppo) then
				Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
end