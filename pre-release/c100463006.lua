--強化反撃
--Enhanced Counter
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When a card or effect is activated that would inflict damage to you: Make that effect damage to you 0. Immediately after that effect resolves, 1 face-up monster you control gains ATK equal to the damage you would have taken.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.avoiddamagecon)
	e1:SetOperation(s.avoiddamageop)
	c:RegisterEffect(e1)
	--During damage calculation, if your monster battles an opponent's monster: Your battling monster gains ATK equal to that opponent's monster's ATK during damage calculation only
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--When you take battle or effect damage: Inflict damage to your opponent equal to the damage you took
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp end)
	e3:SetTarget(s.reflectdamagetg)
	e3:SetOperation(s.reflectdamageop)
	c:RegisterEffect(e3)
end
function s.avoiddamagecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
function s.avoiddamageop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dameff_chainid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local recorded_damage=0
	local e2=Effect.CreateEffect(c)
	--Make that effect damage to you 0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetLabel(dameff_chainid)
	e1:SetValue(function(e,re,val,r,rp,rc)
		if Duel.GetCurrentChain()==0 or (r&REASON_EFFECT)==0 then return val end
		if Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==dameff_chainid then
			e2:SetLabel(val)
			return 0
		else
			return val
		end
	end)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	--Immediately after that effect resolves, 1 face-up monster you control gains ATK equal to the damage you would have taken.
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)==dameff_chainid end)
	e2:SetOperation(s.atkupdateop)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)
end
function s.atkupdateop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local recorded_damage=e:GetLabel()
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.HintSelection(tc)
	tc:UpdateAttack(recorded_damage,RESET_EVENT|RESETS_STANDARD,e:GetHandler())
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local your_monster,opp_monster=Duel.GetBattleMonster(tp)
	return your_monster and opp_monster
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local your_monster,opp_monster=Duel.GetBattleMonster(tp)
	if chk==0 then return opp_monster:GetAttack()>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,your_monster,1,tp,opp_monster:GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local your_monster,opp_monster=Duel.GetBattleMonster(tp)
	if your_monster and your_monster:IsRelateToBattle() and your_monster:IsFaceup() and opp_monster and opp_monster:IsRelateToBattle() and opp_monster:IsFaceup() and opp_monster:GetAttack()>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE_CAL)
		e1:SetValue(opp_monster:GetAttack())
		your_monster:RegisterEffect(e1)
	end
end
function s.reflectdamagetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
function s.reflectdamageop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,ev,REASON_EFFECT)
end