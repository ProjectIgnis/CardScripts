--マジカル・セブンス・フュージョン
--Magical Sevens Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,s.fusfilter,s.matfilter,nil,nil,nil,s.stage2)
end
function s.fusfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefenseBelow(2100)
end
function s.matfilter(c)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		--Prevent non-Spellcasters from attacking
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_SPELLCASTER)
end