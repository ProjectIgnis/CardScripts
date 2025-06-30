--ＯＴＳダイバーシティ・スクリーム
--OuTerverSe Diversity Scream
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={160022200}
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160022200)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	local c=e:GetHandler()
	--Decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(-1000)
	bc:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if dg:GetClassCount(Card.GetAttribute)>1 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		for tc in g:Iter() do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(-2000)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end