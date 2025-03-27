--犀子の王様
--Royal Rhino with Deceitful Dice
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Roll a six-sided die
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,1,tp,0)
	local chain_link=ev+1
	if chain_link==2 then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,500)
	elseif chain_link==3 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,500)
	elseif chain_link>=4 then
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_ONFIELD)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local res=Duel.TossDice(tp,1)
	local chain_link=Duel.GetCurrentChain()
	if chain_link==2 then
		--This card gains ATK equal to the result x 500 until the end of this turn
		local c=e:GetHandler()
		if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(res*500)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	elseif chain_link==3 then
		--Inflict damage to your opponent equal to the result x 500
		Duel.Damage(1-tp,res*500,REASON_EFFECT)
	elseif chain_link>=4 then
		--Destroy cards on the field up to the result
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,res,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end