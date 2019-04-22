--phantasm
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
local m,cm=Senya.SayuriRitualPreload(210765905)
function cm.initial_effect(c)
	Senya.AddSummonMusic(c,m*16,SUMMON_TYPE_RITUAL)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	Senya.NegateEffectModule(c,1,m,cm.DiscardHandCost,cm.negcon,nil,LOCATION_HAND)
	local e2=Senya.NegateEffectModule(c,1,nil,nil,cm.negcon)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local rc=re:GetHandler()
		if not Duel.NegateActivation(ev) then return end
		if rc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 and not rc:IsLocation(LOCATION_HAND+LOCATION_DECK) then
			if rc:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp)>0
				and (not rc:IsLocation(LOCATION_EXTRA) or Duel.GetLocationCountFromEx(tp)>0)
				and rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
				and Duel.SelectYesNo(tp,aux.Stringid(90809975,3)) then
				Duel.BreakEffect()
				Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				Duel.ConfirmCards(1-tp,rc)
			elseif (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
				and rc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(90809975,4)) then
				Duel.BreakEffect()
				Duel.SSet(tp,rc)
				Duel.ConfirmCards(1-tp,rc)
			end
		end
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
			local cat=e:GetCategory()
			if (re:GetHandler():GetOriginalType() & TYPE_MONSTER)~=0 then
				e:SetCategory((cat | CATEGORY_SPECIAL_SUMMON))
			else
				e:SetCategory((cat & ~CATEGORY_SPECIAL_SUMMON))
			end
		end
	end)
end
cm.mat_filter=Senya.SayuriDefaultMaterialFilterLevel12
cm.sayuri_trigger_forced=true
function cm.sayuri_trigger_operation(c,e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(cm.disop3)
	Duel.RegisterEffect(e1,tp)
end
function cm.disop3(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function cm.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and Senya.check_set_sayuri(c)
end
function cm.DiscardHandCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and 
		Duel.IsExistingMatchingCard(cm.costfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST)
end