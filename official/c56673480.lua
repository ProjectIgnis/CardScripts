--ドン・サウザンドの契約
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--public
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.drop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e3:SetCondition(s.pubcon)
	e3:SetTarget(s.pubtg)
	e3:SetLabelObject(g)
	c:RegisterEffect(e3)
	--cannot summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.scon1)
	e4:SetLabelObject(g)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetTargetRange(0,1)
	e6:SetCondition(s.scon2)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e7)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>=1000 and Duel.IsPlayerCanDraw(tp,1)
		and Duel.GetLP(1-tp)>=1000 and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local lp0=Duel.GetLP(tp)
	if lp0>=1000 then
		Duel.SetLP(tp,lp0-1000)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	local lp1=Duel.GetLP(1-tp)
	if lp1>=1000 then
		Duel.SetLP(1-tp,lp1-1000)
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pg=e:GetLabelObject()
	if c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1)
		pg:Clear()
	end
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		pg:AddCard(tc)
		tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	return false
end
function s.pubcon(e)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.pubtg(e,c)
	return e:GetLabelObject():IsContains(c) and c:GetFlagEffect(id+1)~=0
end
function s.sfilter(c,pg)
	return c:IsPublic() and pg:IsContains(c) and c:GetFlagEffect(id+1)>0 and c:IsType(TYPE_SPELL)
end
function s.scon1(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND,0,1,nil,e:GetLabelObject())
end
function s.scon2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.sfilter,tp,0,LOCATION_HAND,1,nil,e:GetLabelObject())
end
