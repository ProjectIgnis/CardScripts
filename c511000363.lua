--Dynamite Dragon
local s,id=GetID()
function s.initial_effect(c)
	--deckdes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return (e:GetHandler():GetReasonEffect() and e:GetHandler():GetReasonEffect():GetOwner():IsType(TYPE_MONSTER)) 
		or (e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():GetReasonCard():IsRelateToBattle()) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=(e:GetHandler():GetReasonEffect() and e:GetHandler():GetReasonEffect():GetOwner()) 
		or (e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():GetReasonCard())
	if tc and tc:IsRelateToBattle()(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-300)
		tc:RegisterEffect(e1)
	end
end
