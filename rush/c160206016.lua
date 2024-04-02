--鋼鉄馬マーチン・ヴァイナリー
--Steel Steed Martin Vinary
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Toss a coin
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	return Duel.GetFieldGroupCountRush(tp,0,LOCATION_MZONE)>0
		and e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0
		and Duel.IsAbleToEnterBP()
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCountRush(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local heads=Duel.CountHeads(Duel.TossCoin(tp,ct))
	--Effect
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		if heads>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3201)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(1)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
		if heads==3 then c:AddPiercing(RESETS_STANDARD_PHASE_END) end
	end
end