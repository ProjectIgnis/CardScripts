--魔界即興劇－インプロ
--Abyss Improv
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Change battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x10ec}
function s.filter(c,g)
	return c:IsFaceup() and c:IsSetCard(SET_ABYSS_ACTOR) and c:IsLevelBelow(4)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	local g=Group.FromCards(a)
	if d then g:AddCard(d) end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and not g:IsContains(chkc) and s.filter(chkc) end
	if chk==0 then return d and g:IsExists(Card.IsControler,1,nil,1-tp)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,g)
end
function s.activate(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e1:SetCountLimit(1)
		e1:SetOperation(s.rdop)
		e1:SetLabel(tc:GetAttack())
		Duel.RegisterEffect(e1,tp)
	end
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev+e:GetLabel())
end