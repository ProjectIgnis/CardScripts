--凶導の福音
--Dogmatikalamity
--scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon any "Dogmatika" Ritual Monster
	local e1=Ritual.CreateProc({
				handler=c,
				lvtype=RITPROC_EQUAL,
				filter=function(c) return c:IsSetCard(SET_DOGMATIKA) end,
				extrafil=function(e,tp) return Duel.GetMatchingGroup(aux.AND(Card.HasLevel,Card.IsAbleToGrave),tp,LOCATION_EXTRA,0,nil) end,
				extraop=s.extraop,
				stage2=s.stage2,
				forcedselection=s.ritcheck
	})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DOGMATIKA}
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local extra_mat=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	if #extra_mat>0 then
		Duel.SendtoGrave(extra_mat,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
	else
		Duel.ReleaseRitualMaterial(mat)
	end
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--For the rest of this turn after this card resolves, you cannot Special Summon monsters from the Extra Deck
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ritcheck(e,tp,g,sc)
	local extra_ct=g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	return extra_ct==0 or #g==1,extra_ct>1 or (extra_ct==1 and #g>1)
end
