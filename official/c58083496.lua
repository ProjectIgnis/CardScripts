--JP name
--Odd-Eyes Override Dragon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including a Pendulum Monster
	Link.AddProcedure(c,nil,2,3,s.matcheck)
	--You can target 1 other card you control; destroy it, and if you do, draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--During your turn, when your opponent activates a card or effect (Quick Effect): You can discard 1 card; negate that effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(tp) and rp==1-tp and Duel.IsChainDisablable(ev)
	end)
	e2:SetCost(Cost.Discard())
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.NegateEffect(ev)
	end)
	c:RegisterEffect(e2)
	--If you destroyed a Pendulum Monster Card by this card's first effect, during your Main Phase this turn, you can conduct 1 Pendulum Summon of a "Performapal" monster(s), "Magician" Pendulum Monster(s), and/or "Odd-Eyes" monster(s), in addition to your Pendulum Summon (you can only gain this effect once per turn)
	local extra_pendulum_effect=Pendulum.CreateAdditionalPendulumSummonEffect(c,s.pendulumfilter,nil,aux.Stringid(id,2),id)
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetTargetRange(LOCATION_SZONE,0)
	e3a:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_PZONE)
	end)
	e3a:SetCondition(function(e)
		return e:GetHandler():HasFlagEffect(id)
	end)
	e3a:SetLabelObject(extra_pendulum_effect)
	c:RegisterEffect(e3a)
	local harmonic_effect=Pendulum.CreateHarmonicOscillationEffect(c,s.pendulumfilter,aux.Stringid(id,2),id)
	local e3b=e3a:Clone()
	e3b:SetLabelObject(harmonic_effect)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_PERFORMAPAL,SET_MAGICIAN,SET_ODD_EYES}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_PENDULUM,lc,sumtype,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and chkc~=c end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsOriginalType(TYPE_PENDULUM) then
			c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		end
	end
end
function s.pendulumfilter(c)
	return c:IsSetCard({SET_PERFORMAPAL,SET_ODD_EYES}) or (c:IsSetCard(SET_MAGICIAN) and c:IsPendulumMonster())
end