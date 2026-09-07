--アルバスの落胤
--Fallen of Albaz
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local params={nil,Fusion.CheckWithHandler(aux.FALSE),s.fextra,nil,Fusion.ForcedHandler}
	--Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters on either field as Fusion Material, including this card, but you cannot use other monsters you control as Fusion Material
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetCondition(function() return not Duel.IsDamageStep() end)
	e1a:SetCost(Cost.Discard())
	e1a:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1a:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
end
function s.fcheck(c)
	return function(tp,sg,fc)
		return not sg:IsExists(aux.AND(Card.IsControler,Card.IsOnField),1,c,tp)
	end
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil),s.fcheck(e:GetHandler())
end