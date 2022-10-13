--Rule of the day "Ritual Re-rite"
local s,id=GetID()
function s.initial_effect(c)
	aux.GlobalCheck(s,function()
		--place field
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetOperation(s.activate)
		Duel.RegisterEffect(e1,0)
	end)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.searchcon)
	e1:SetTarget(s.searchtg)
	e1:SetOperation(s.searchop)
	Duel.RegisterEffect(e1,0)
	local e2=e1:Clone()
	Duel.RegisterEffect(e2,1)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcond)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.tgop)
	Duel.RegisterEffect(e3,0)
	local e4=e3:Clone()
	Duel.RegisterEffect(e4,1)
end
function s.thfilter(c)
	return c:IsRitualSpell() and c:IsAbleToHand()
end
function s.searchcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0 and Duel.IsTurnPlayer(tp)
end
function s.searchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	local apply=0
	if Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(4388680,1)) then
		apply=1
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	end
	e:SetLabel(apply)
end 
function s.searchop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+1)==0
end
function s.thfilter2(c,id)
	return (c:GetReason()&REASON_RITUAL)>0 and c:IsMonster() and c:GetTurnID()==id and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,nil,Duel.GetTurnCount()) end
	local apply=0
	if Duel.GetFlagEffect(tp,id+1)==0 and Duel.SelectYesNo(tp,aux.Stringid(37021315,1)) then
		apply=1
	end
	e:SetLabel(apply)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil,Duel.GetTurnCount())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
