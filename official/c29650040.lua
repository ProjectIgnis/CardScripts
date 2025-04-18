--ドレミコード・ハルモニア
--Solfachord Harmonia
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SOLFACHORD}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.pentg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.destg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	if sel==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(s.thop)
		s.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif sel==2 then
		e:SetOperation(s.penop)
		s.pentg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif sel==3 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetOperation(s.desop)
		s.destg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SOLFACHORD) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.penfilter(c)
	return c:IsSetCard(SET_SOLFACHORD) and c:GetOriginalLevel()>0
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
function s.descfilter(c,f)
	return c:IsFaceup() and c:IsSetCard(SET_SOLFACHORD) and c:IsOriginalType(TYPE_PENDULUM) and c:IsOriginalType(TYPE_MONSTER) and f(c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then 
		local pg1=Duel.GetMatchingGroup(s.descfilter,tp,LOCATION_ONFIELD,0,nil,Card.IsOddScale)
		local pg2=Duel.GetMatchingGroup(s.descfilter,tp,LOCATION_ONFIELD,0,nil,Card.IsEvenScale)
		return Duel.GetFlagEffect(tp,id+2)==0 and #g>0 and
		(pg1:GetClassCount(Card.GetLeftScale)>=3 or pg2:GetClassCount(Card.GetLeftScale)>=3
		or pg1:GetClassCount(Card.GetRightScale)>=3 or pg2:GetClassCount(Card.GetRightScale)>=3)
	end
	Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end