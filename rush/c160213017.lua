--チェンジ・スライム－悪魔竜形態
--Change Slime - Fiend Dragon Mode
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local params = {s.filter}
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
	return c:ListsCodeAsMaterial(CARD_SUMMONED_SKULL,CARD_REDEYES_B_DRAGON)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.operation(fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Requirement
		if Duel.SendtoGrave(e:GetHandler(),REASON_COST)<1 then return end
		--Effect
		fusop(e,tp,eg,ep,ev,re,r,rp)
	end
end