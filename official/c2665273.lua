--永の王 オルムガンド
--Jormungandr, Generaider Boss of Eternity
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	Xyz.AddProcedure(c,nil,9,2,nil,nil,99)
	--atk/def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
function s.filter(c)
	return not c:IsType(TYPE_TOKEN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ps={}
	local pc=false
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		table.insert(ps,tp)
		pc=true
	end
	if Duel.Draw(1-tp,1,REASON_EFFECT)>0 then
		table.insert(ps,1-tp)
		pc=true
	end
	if not (pc and c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	Duel.BreakEffect()
	for _,p in pairs(ps) do
	local g=Duel.SelectMatchingCard(p,s.filter,p,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
		if #g>0 then
			local og=g:GetFirst():GetOverlayGroup()
			if #og>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
			g:GetFirst():CancelToGrave()
			Duel.Overlay(c,g)
		end
	end
end
