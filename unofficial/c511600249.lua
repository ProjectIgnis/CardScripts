--ドローン・フォース・フュージョン
--Drone Force Fusion
--scripted by Larry126
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	----Fusion Summon 1 Fusion monster, using monsters you control as material, including a "Drone" monster
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=Fusion.OnFieldMat,extrafil=function() return nil,s.matcheck end,stage2=s.stage2})
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={0x581}
function s.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsDrone,1,nil,fc,SUMMON_TYPE_FUSION,tp)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Cannot be destroyed by card effects
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(3001)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		if not tc:IsType(TYPE_EFFECT) then
			--Becomes an Effect Monster if it wasn't one already
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end
end