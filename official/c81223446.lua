--死魂融合
--Necro Fusion

local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon 1 fusion monster
	--Banish monsters from GY, face-down, as material
	local e1=Fusion.CreateSummonEff(c,nil,s.matfilter,s.fextra,s.extraop,nil,s.stage2)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
function s.matfilter(c)
	return aux.SpElimFilter(c) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		--Cannot attack this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end