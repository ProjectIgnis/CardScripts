--Keep the Faith -Sayuri Remix-
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
local m,cm=Senya.SayuriRitualPreload(210765910)
cm.Senya_name_with_remix=true
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,m)
	e1:SetCost(Senya.SelfDiscardCost)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return re:GetHandler():IsOnField() and re:IsActiveType(TYPE_MONSTER) and ep~=tp
	end)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(0x14000)
	e1:SetTarget(cm.atktg)
	e1:SetOperation(cm.atkop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c) 
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCondition(cm.spcon1)
	e3:SetTarget(cm.distg)
	e3:SetOperation(cm.disop)
	c:RegisterEffect(e3) 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetTarget(cm.distg)
	e4:SetOperation(cm.disop)
	c:RegisterEffect(e4)
end
cm.mat_filter=Senya.SayuriDefaultMaterialFilterLevel8
function cm.filter(c,code,e)
	if c:IsFacedown() then return false end
	if e then
		if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return false end
	else
		if not Senya.check_set_sayuri(c) then return false end
	end
	local l=c:GetFlagEffectLabel(m)
	if not l then return true end
	for i,v in pairs(Senya.order_table[l]) do
		if v==code then return false end
	end
	return true
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and cm.filter(chkc,e:GetLabel()) end
	if chk==0 then return re:GetHandler():IsOnField() and re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsType(TYPE_TRAPMONSTER) and Duel.IsExistingTarget(cm.filter,tp,LOCATION_MZONE,0,1,nil,re:GetHandler():GetOriginalCode()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_MZONE,0,1,1,nil,re:GetHandler():GetOriginalCode())
	e:SetLabel(re:GetHandler():GetOriginalCode())
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if tc and cm.filter(tc,code,e) then
		tc:CopyEffect(code,RESET_EVENT+0x1fe0000,1)
	end
end
function cm.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.rmfilter,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
function cm.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local g=Duel.GetMatchingGroup(cm.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if #g==0 then return end
	local gc=g:RandomSelect(tp,1):GetFirst()
	Duel.Remove(gc,POS_FACEUP,REASON_EFFECT)
	local tc=Duel.GetOperatedGroup():GetFirst()
			local tc=Duel.GetOperatedGroup():GetFirst()
			local code=tc:GetOriginalCode()
			local atk=tc:GetBaseAttack()
			local def=tc:GetBaseDefense()
			local e1=Effect.CreateEffect(e:GetHandler())
			local res,resct=0x1fe1000,1
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(res,resct)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(code)
			c:RegisterEffect(e1)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(res,resct)
			e3:SetCode(EFFECT_SET_BASE_ATTACK)
			e3:SetValue(atk)
			c:RegisterEffect(e3)
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetReset(res,resct)
			e4:SetCode(EFFECT_SET_BASE_DEFENSE)
			e4:SetValue(def)
			c:RegisterEffect(e4)
			if tc:IsType(TYPE_TRAPMONSTER) then return end
			local f=Card.RegisterEffect
			Card.RegisterEffect=function(tc,e,forced)
				local t=e:GetType()
				if (t & EFFECT_TYPE_IGNITION)~=0 then
					e:SetType((t-EFFECT_TYPE_IGNITION | EFFECT_TYPE_QUICK_O))
					e:SetCode(EVENT_FREE_CHAIN)
					e:SetHintTiming(0,0x1e0)
				end
				f(tc,e,forced)
			end
			c:CopyEffect(code,res,resct)
			Card.RegisterEffect=f
end
function cm.spcon1(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(e:GetHandler())
end
function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)==0 then return end
	if not e:GetHandler():IsLocation(LOCATION_REMOVED) or not e:GetHandler():IsType(TYPE_MONSTER) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetReset(0x1fe1000+RESET_PHASE+PHASE_END)
	e1:SetCondition(function(e,tp)
		return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) and Duel.GetMZoneCount(tp)>0
	end)
	e1:SetOperation(function(e,tp)
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,true,POS_FACEUP)
		e:GetHandler():CompleteProcedure()
	end)
	e:GetHandler():RegisterEffect(e1,true)
end