--先手必掌
--Early Palm Gets the Win
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Roll a six-sided die and apply this effect to that monster you control based on the result until the end of this turn, or, if you activated this effect when an attack was declared involving 2 monsters in the same column, you choose the effect instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.GetBattleMonster(tp) end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.roll_dice=true
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc1=Duel.GetBattleMonster(tp)
	local bc2=bc1:GetBattleTarget()
	if bc2 and bc1:GetColumnGroup():IsContains(bc2) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	e:SetLabelObject(bc1)
	bc1:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if not bc:IsRelateToEffect(e) then return end
	local op=nil
	if e:GetLabel()==0 then
		op=Duel.TossDice(tp,1)
	else
		local is_faceup=bc:IsFaceup()
		op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,1)},
			{is_faceup,aux.Stringid(id,2)},
			{is_faceup,aux.Stringid(id,3)})
	end
	local c=e:GetHandler()
	if op==1 or op==4 then
		--● 1 or 4: The first time it would be destroyed by battle or card effect, it is not destroyed
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(function(e,re,r,rp) return r&(REASON_BATTLE|REASON_EFFECT)>0 end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		bc:RegisterEffect(e1)
	elseif op==2 or op==5 then
		--● 2 or 5: It loses 500 ATK, also it is unaffected by activated Spell/Trap effects, except "Early Palm Gets the Win"
		bc:UpdateAttack(-500,RESETS_STANDARD_PHASE_END,c)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,5))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(function(e,te) return te:IsActivated() and te:IsSpellTrapEffect() and not te:GetHandler():IsCode(id) end)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		bc:RegisterEffect(e2)
	elseif op==3 or op==6 then
		--● 3 or 6: It gains 1000 ATK, also it can make up to 2 attacks on monsters during each Battle Phase
		bc:UpdateAttack(1000,RESETS_STANDARD_PHASE_END,c)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,6))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e3:SetValue(1)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		bc:RegisterEffect(e3)
	end
end