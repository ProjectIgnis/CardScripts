--レッド・デーモンズ・チェーン
--Red Dragon Archfiend's Chain
--scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--You can activate this card the turn it was Set, by revealing 1 "Red Dragon Archfiend" in your Extra Deck
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetValue(function(e) e:SetLabel(1) end)
	e0:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.extracostfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,1,nil) end)
	c:RegisterEffect(e0)
	--Activate this card by revealing any number of monsters in your hand, then target Effect Monsters your opponent controls equal to the number of Tuners revealed +1; they lose 100 ATK for each card revealed, also their effects are negated
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabelObject(e0)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--They lose 100 ATK for each card revealed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.PersistentTargetFilter)
	e2:SetValue(function() return e1:GetLabel()*-100 end)
	c:RegisterEffect(e2)
	--Also their effects are negated
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND}
function s.handcostfilter(c)
	return c:IsMonster() and not c:IsPublic()
end
function s.rescon(max_target_count)
	return function(sg,e,tp,mg)
		return sg:FilterCount(Card.IsType,nil,TYPE_TUNER)+1<=max_target_count
	end
end
function s.extracostfilter(c)
	return c:IsCode(CARD_RED_DRAGON_ARCHFIEND) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	local hg=Duel.GetMatchingGroup(s.handcostfilter,tp,LOCATION_HAND,0,nil)
	local max_target_count=Duel.GetTargetCount(aux.FaceupFilter(Card.IsEffectMonster),tp,0,LOCATION_MZONE,nil)
	local rescon=s.rescon(max_target_count)
	if chk==0 then label_obj:SetLabel(0) return #hg>0 and max_target_count>0
		and aux.SelectUnselectGroup(hg,e,tp,1,#hg,rescon,0) end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.extracostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleExtra(tp)
	end
	local sg=aux.SelectUnselectGroup(hg,e,tp,1,#hg,rescon,1,tp,HINTMSG_CONFIRM,rescon)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	e:SetLabel(sg:FilterCount(Card.IsType,nil,TYPE_TUNER)+1,#sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsEffectMonster() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsEffectMonster),tp,0,LOCATION_MZONE,1,nil) end
	local target_count,reveal_count=e:GetLabel()
	e:SetLabel(reveal_count)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsEffectMonster),tp,0,LOCATION_MZONE,target_count,target_count,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #tg>0 then
		local c=e:GetHandler()
		for tc in tg:Iter() do
			c:SetCardTarget(tc)
		end
		--If the last of those monsters is not on the field, destroy this card
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_SELF_DESTROY)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(function(e) return #(e:GetHandler():GetCardTarget())==0 end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end