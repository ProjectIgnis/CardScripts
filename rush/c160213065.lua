--夢中の抱擁
--Delirium Embrace
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.CreateSummonEff(c,s.ffilter,Fusion.OnFieldMat(Card.IsFaceup),s.fextra,nil,nil,s.stage2))
end
function s.ffilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.fusfilter(c,tp)
	return c:IsControler(tp)
end
function s.checkmat(tp,sg,fc)
	local mg1=sg:Filter(s.fusfilter,nil,tp)
	return #sg==2 and #mg1>0
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.FaceupFilter(Card.IsLevelBelow,9)),tp,0,LOCATION_ONFIELD,nil),s.checkmat
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		--Prevent non-Insect from attacking
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(_,c) return not c:IsRace(RACE_INSECT) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end