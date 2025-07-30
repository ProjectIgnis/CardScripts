--メガリス・ノートラ・プルーラ
--Megalith Nortra Phulra
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeRitualSummoned()
	--Apply a "this turn, your opponent cannot activate cards or effects in response to the activation of your "Megalith" Ritual Monsters' effects" effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return not Duel.HasFlagEffect(tp,id) end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Negate the activation of an opponent's card or effect, and if you do, destroy that card, then if that effect targeted a card(s) on the field, you can Tribute 1 monster your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev) return ep==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MEGALITH}
s.mat_filter=Card.IsRitualMonster
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	--This turn, your opponent cannot activate cards or effects in response to the activation of your "Megalith" Ritual Monsters' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(s.inactop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.inactop(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp then return end
	local trig_typ,trig_setcodes=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_SETCODES)
	if trig_typ&(TYPE_RITUAL|TYPE_MONSTER)~=(TYPE_RITUAL|TYPE_MONSTER) then return end
	for _,setcode in ipairs(trig_setcodes) do
		if (SET_MEGALITH&0xfff)==(setcode&0xfff) and (SET_MEGALITH&setcode)==SET_MEGALITH then
			return Duel.SetChainLimit(function(e,rp,tp) return rp==tp end)
		end
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if tg and tg:IsExists(Card.IsOnField,1,nil) then
		e:SetLabel(100)
		Duel.SetPossibleOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
	else
		e:SetLabel(0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
		if e:GetLabel()==100 and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.Release(g,REASON_EFFECT)
			end
		end
	end
end
