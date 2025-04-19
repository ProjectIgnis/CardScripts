--永の王 オルムガンド
--Jormungandr, Generaider Boss of Eternity
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	Xyz.AddProcedure(c,nil,9,2,nil,nil,Xyz.InfiniteMats)
	--This card's original ATK/DEF become 1000 x its number of materials
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
	--Each player draws 1 card and attaches 1 card to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.Detach(1,1,nil))
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
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
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
		local tc=Duel.SelectMatchingCard(p,Card.IsCanBeXyzMaterial,p,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,c,tp,REASON_EFFECT):GetFirst()
		if tc then
			tc:CancelToGrave()
			Duel.Overlay(c,tc,true)
		end
	end
end