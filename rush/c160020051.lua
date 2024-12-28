--ギャラクシー・カオス・フュージョン
--Galaxy Chaos Fusion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,aux.FilterBoolFunction(s.fusfilter),nil,function(e,tp,mg) return nil,s.fcheck end,nil,nil,s.stage2)
end
function s.fusfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsLevel(9)
end
function s.matfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY)
end
function s.matfilter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
function s.fcheck(tp,sg,fc)
	local mg1=sg:Filter(s.matfilter1,nil)
	local mg2=sg:Filter(s.matfilter2,nil)
	return #sg==2 and #mg1==1 and #mg2==1
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetOriginalLevel()>=7
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		local mg=tc:GetMaterial()
		local ct=mg:FilterCount(s.cfilter,nil)
		if ct==2 and Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,2,nil)
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end