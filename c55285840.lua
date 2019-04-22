--Time Thief Redoer
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,4,2)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	--detach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #(Duel.GetDecktopGroup(1-tp,1))==1 end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(1-tp,1)
	if c:IsRelateToEffect(e) and #g==1 then
		Duel.DisableShuffleCheck()
		Duel.Overlay(c,g)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
		and sg:FilterCount(Card.IsType,nil,TYPE_SPELL)<=1
		and sg:FilterCount(Card.IsType,nil,TYPE_TRAP)<=1
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local ty=0
	if c:IsAbleToRemove() then ty=ty | TYPE_MONSTER end
	if Duel.IsPlayerCanDraw(tp,1) then ty=ty | TYPE_SPELL end
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,nil) then ty=ty | TYPE_TRAP end
	if chk==0 then return ty>0 and g:IsExists(Card.IsType,1,nil,ty) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetOverlayGroup()
	local ty=0
	if c:IsAbleToRemove() then ty=ty | TYPE_MONSTER end
	if Duel.IsPlayerCanDraw(tp,1) then ty=ty | TYPE_SPELL end
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,nil) then ty=ty | TYPE_TRAP end
	if ty==0 then return end
	local sg=aux.SelectUnselectGroup(g:Filter(Card.IsType,nil,ty),e,tp,1,3,s.rescon,1,tp,HINTMSG_XMATERIAL)
	local lb=0
	for tc in aux.Next(sg) do
		lb=lb | tc:GetType()
	end
	lb=lb & 0x7
	Duel.SendtoGrave(sg,REASON_EFFECT)
	Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	Duel.BreakEffect()
	if lb & TYPE_MONSTER ~=0 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			Duel.RegisterEffect(e1,tp)
		end
	end
	if lb & TYPE_SPELL ~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if lb & TYPE_TRAP ~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then Duel.SendtoDeck(g,nil,0,REASON_EFFECT) end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
