--歴戦の暗黒騎士ガイア
--Battletested Gaia The Fierce Knight
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--Change name to "Curse of Dragon" and Fusion Summon
	local params={nil,Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial,Fusion.ForcedHandler,nil,2}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e2)
end
s.listed_names={6368038} --Gaia the Fierce Knight
function s.otfilter(c)
	return c:IsLevelAbove(5) and c:IsFaceup()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.operation(oldtg,oldop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		-- Requirement
		if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
		--Effect
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(6368038)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		if oldtg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			oldop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end