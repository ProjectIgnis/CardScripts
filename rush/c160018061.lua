--バーニング・ウィンド
--Burning Wind
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Increase the ATK of 1 Warrior you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	return at and tc and at:IsControler(1-tp) and at:IsLevelAbove(5)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		--Increase ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		local ag,da=eg:GetFirst():GetAttackableTarget()
		local at=Duel.GetAttackTarget()
		if (ag:IsExists(aux.TRUE,1,at) or (at~=nil and da)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			if da and at~=nil then
				local sel=0
				Duel.Hint(HINT_SELECTMSG,tp,31)
				if ag:IsExists(aux.TRUE,1,at) then
					sel=Duel.SelectOption(tp,1213,1214)
				else
					sel=Duel.SelectOption(tp,1213)
				end
				if sel==0 then
					Duel.ChangeAttackTarget(nil)
					return
				end
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
			local tc=ag:Select(tp,1,1,at):GetFirst()
			if tc then
				Duel.ChangeAttackTarget(tc)
			end
		end
	end
end