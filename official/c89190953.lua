--次元融合殺
--Dimension Fusion Destruction
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x145),extrafil=s.fextra,chkf=FUSPROC_NOTFUSION|FUSPROC_LISTEDMATS,stage2=s.stage2,extraop=Fusion.BanishMaterial})
	local tg=e1:GetTarget()
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					tg(e,tp,eg,ep,ev,re,r,rp,chk)
					if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,6007213,32491822,69890967),tp,LOCATION_MZONE,0,1,nil)
						and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler()==e:GetOwner() then
						Duel.SetChainLimit(s.chlimit)
					end
				end)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_series={0x145}
s.listed_names={6007213,32491822,69890967}
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
