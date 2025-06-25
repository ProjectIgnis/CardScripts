--サイバー・サベイランス・ドラゴン
--Cyber Surveillance Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160402022,CARD_CYBER_DRAGON)
	--Fusion Summon
	local params = {s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,3}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(s.operation(Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsLevel(10) and c:IsRace(RACE_MACHINE)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsCode(CARD_CYBER_DRAGON) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk~=1 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e1,true)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackPos() and c:IsCanChangePositionRush() end
end
function s.operation(fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Requirement
		if Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE,0,0,0)<1 then return end
		--Effect
		fusop(e,tp,eg,ep,ev,re,r,rp)
	end
end