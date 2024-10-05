--マキシマム・フレア・フュージョン
--Maximum Flare Fusion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),Fusion.OnFieldMat,s.fextra,nil,nil,s.stage2))
end
function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MAXIMUM)
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(s.matfilter,1,nil)
end
function s.fextra(e,tp,mg)
	local fusg=Duel.GetMatchingGroup(Fusion.OnFieldMat,tp,LOCATION_MZONE,0,nil)
	local extrag=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_HAND,0,nil)
	fusg:Merge(extrag)
	return fusg,s.checkmat
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:WasMaximumMode()
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		local mg=tc:GetMaterial()
		local ct=mg:FilterCount(s.cfilter,nil)
		if ct>0 then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(3060)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetValue(aux.indoval)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc:AddPiercing(RESET_EVENT|RESETS_STANDARD,e:GetHandler())
		end
	end
end