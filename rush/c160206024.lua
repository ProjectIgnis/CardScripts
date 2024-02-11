--ドラゴン・トライブ・フュージョン
--Dragon Tribe Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,nil,aux.FALSE,s.fextra,Fusion.ShuffleMaterial,nil,s.stage2)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==1
end
function s.exfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and (c:IsType(TYPE_NORMAL) or c:IsLocation(LOCATION_GRAVE))
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if #eg>0 then
		return eg,s.fcheck
	end
	return nil
end
function s.stage2(e,tc,tp,mg,chk)
	--Prevent non-Fusion from attacking
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ftarget(e,c)
	return not c:IsType(TYPE_FUSION)
end