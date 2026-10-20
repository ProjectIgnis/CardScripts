--ダーク・フュージョン (Rush)
--Dark Fusion (Rush)
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon a Fiend Type monster by sending monsters from your hand or field to the Graveyard as material.
	c:RegisterEffect(Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),stage2=s.stage2}))
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 and tc:ListsCode(CARD_DARK_FUSION) then
		--If you Special Summoned a monster that mentions "Dark Fusion" by this effect, it cannot be destroyed by card effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end