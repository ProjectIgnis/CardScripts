--ワンハンドレッド·アイ·ドラゴン (Anime)
--Hundred Eyes Dragon (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--dark synchro summon
	c:EnableReviveLimit()
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTuner(nil),nil,8)
	--add setcode
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(0x601)
	c:RegisterEffect(e1)
	--copy  
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE) 
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(135598,0))
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()  
	local wg=Duel.GetMatchingGroup(s.filter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local wbc=wg:GetFirst()
	while wbc do
		local code=wbc:GetOriginalCode()
		if c:IsFaceup() and c:GetFlagEffect(code)==0 then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
			c:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		wbc=wg:GetNext()
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
