--セレブローズ・ファビュラス・マジシャン
--Celeb Rose Fabulous Magician
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_CELEB_ROSE_MAGICIAN,CARD_CELEB_ROSE_WITCH)
	--Destroy 1 face-up monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.filter(c)
	return c:IsMonster() and c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #dg>0 end
end
function s.thfilter(c)
	return c:IsEquipSpell() and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		if #dg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg,true)
			if Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
				if #g>0 then
					Duel.BreakEffect()
					Duel.HintSelection(g,true)
					Duel.SendtoHand(g,nil,REASON_EFFECT)
				end
			end
		end
	end
end